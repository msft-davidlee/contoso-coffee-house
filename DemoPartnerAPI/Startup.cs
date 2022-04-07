using DemoPartnerCore;
using DemoPartnerCore.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using DemoCore;

namespace DemoPartnerAPI
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.EnableApplicationInsights(Configuration);
            services.AddLogging();
            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(Configuration.GetConnectionString(),
                    sqlServerOptionsAction: sqlOptions =>
                    {
                        sqlOptions.EnableRetryOnFailure();
                    });
            });
            services.AddTransient<IDbServiceFactory, DbServiceFactory>();
            services.AddTransient<IProductService, ProductService>();
            services.AddTransient<IOrderService, OrderService>();
            services.AddTransient<IShippingService, ShippingService>();

            var healthChecks = services.AddHealthChecks()
                .AddCheck<ProductService>("Database");

            string shippingRepositoryType = Configuration["ShippingRepositoryType"];
            switch (shippingRepositoryType)
            {
                case "Storage":
                    services.AddTransient<IShippingRepository, StorageQueueShippingRepository>();
                    healthChecks.AddCheck<StorageQueueShippingRepository>("Queue");
                    break;

                case "ServiceBus":
                    services.AddTransient<IShippingRepository, ServiceBusShippingRepository>();
                    healthChecks.AddCheck<ServiceBusShippingRepository>("Queue");
                    break;

                default:
                    throw new ApplicationException("ShippingRepositoryType is not configured.");
            }

            services.AddControllers();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            // TODO: Make this configurable.
            //app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHealthChecks("/health").AllowAnonymous();
            });
        }
    }
}
