using DemoWebsite.Core;
using DemoWebsite.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using System.IO;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.Identity.Web;
using Microsoft.Identity.Web.UI;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.AspNetCore.HttpOverrides;
using System;
using DemoCore;
using System.Threading.Tasks;

namespace DemoWebsite
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        private bool IsForwardHeaderEnabled()
        {
            return string.Equals(Environment.GetEnvironmentVariable("ASPNETCORE_FORWARDEDHEADERS_ENABLED"), "true", StringComparison.OrdinalIgnoreCase);
        }

        private const string VersionFileName = "version.txt";

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.EnableApplicationInsights(Configuration);
            services.AddLogging();

            services.AddSingleton<IManagedConfiguration>(new ManagedConfiguration(
                File.Exists(VersionFileName) ? File.ReadAllText(VersionFileName) : null,
                Environment.MachineName));

            // https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/proxy-load-balancer?view=aspnetcore-6.0#forward-the-scheme-for-linux-and-non-iis-reverse-proxies
            if (IsForwardHeaderEnabled())
            {
                services.Configure<ForwardedHeadersOptions>(options =>
                {
                    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor |
                        ForwardedHeaders.XForwardedProto;
                    // Only loopback proxies are allowed by default.
                    // Clear that restriction because forwarders are enabled by explicit 
                    // configuration.
                    options.KnownNetworks.Clear();
                    options.KnownProxies.Clear();
                });
            }

            if (IsAuth())
            {
                //if (ConfigureForB2C())
                //{
                services.AddMicrosoftIdentityWebAppAuthentication(Configuration, "AzureAd")
                    .EnableTokenAcquisitionToCallDownstreamApi()
                    .AddInMemoryTokenCaches();
                //}
                //else
                //{
                //    services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
                //        .AddMicrosoftIdentityWebApp(Configuration.GetSection("AzureAd"))
                //        .EnableTokenAcquisitionToCallDownstreamApi()
                //        .AddInMemoryTokenCaches();
                //}

                var overrideHostname = Configuration["OverrideAuthRedirectHostName"];
                if (!string.IsNullOrEmpty(overrideHostname))
                {
                    services.Configure<OpenIdConnectOptions>(OpenIdConnectDefaults.AuthenticationScheme, options =>
                    {
                        options.SaveTokens = true; // this saves the token for the downstream api
                        options.Events = new OpenIdConnectEvents
                        {
                            OnRedirectToIdentityProvider = async ctxt =>
                            {

                                ctxt.ProtocolMessage.RedirectUri = overrideHostname;
                                await Task.Yield();
                            }
                        };
                    });
                }

                services.AddControllersWithViews(options =>
                {
                    var policy = new AuthorizationPolicyBuilder()
                        .RequireAuthenticatedUser()
                        .Build();
                    options.Filters.Add(new AuthorizeFilter(policy));
                });
            }

            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(Configuration.GetConnectionString(),
                    sqlServerOptionsAction: sqlOptions =>
                    {
                        sqlOptions.EnableRetryOnFailure();
                    });
            });
            services.AddTransient<IDbServiceFactory, DbServiceFactory>();
            services.AddTransient<IRewardItemService, RewardItemService>();
            services.AddTransient<IRewardService, RewardService>();
            services.AddTransient<IProductService, ProductService>();
            services.AddTransient<IOrderService, HttpOrderService>();
            services.AddTransient<IAlternateIdService, HttpAlternateIdService>();
            services.AddTransient<IRewardCustomerPointsService, RewardCustomerPointsService>();

            // https://docs.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/use-httpclientfactory-to-implement-resilient-http-requests#how-to-use-typed-clients-with-ihttpclientfactory
            services.AddHttpClient<IMemberService, MemberService>();

            services.AddHealthChecks()
                .AddCheck<IRewardCustomerPointsService>("Database")
                .AddCheck<HttpAlternateIdService>("AlternateIdService")
                .AddCheck<ProductService>("ProductService")
                .AddCheck<MemberService>("MemberService");

            var svc = services.AddRazorPages();

            if (IsAuth())
            {
                svc.AddMicrosoftIdentityUI();

                if (ConfigureForB2C())
                {
                    services.AddOptions();
                    services.Configure<OpenIdConnectOptions>(Configuration.GetSection("AzureAd"));
                }
            }
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();

                if (IsForwardHeaderEnabled())
                    app.UseForwardedHeaders();
            }
            else
            {
                app.UseExceptionHandler("/Error");

                if (IsForwardHeaderEnabled())
                    app.UseForwardedHeaders();

                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            if (IsAuth()) app.UseAuthentication();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapRazorPages();
                endpoints.MapControllers();
                endpoints.MapHealthChecks("/health").AllowAnonymous();
            });
        }

        private bool IsAuth()
        {
            bool result;
            bool.TryParse(Configuration["EnableAuth"], out result);
            return result;
        }

        private bool ConfigureForB2C()
        {
            bool result;
            bool.TryParse(Configuration["ConfigureForB2C"], out result);
            return result;
        }
    }
}
