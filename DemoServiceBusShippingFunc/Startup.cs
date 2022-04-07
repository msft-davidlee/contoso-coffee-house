using DemoCore;
using DemoPartnerCore;
using DemoPartnerCore.Models;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.IO;

[assembly: FunctionsStartup(typeof(DemoServiceBusShippingFunc.Startup))]
namespace DemoServiceBusShippingFunc
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var configuration = builder.GetContext().Configuration;

            string value = configuration["Connection"];
            if (value.StartsWith("FilePath="))
            {
                string filePath = value.Split('=')[1];
                value = File.ReadAllText(filePath);
                Environment.SetEnvironmentVariable("Connection", value);
            }

            builder.Services.AddDbContext<AppDbContext>(options =>
            {
                options.UseSqlServer(configuration.GetConnectionString(),
                    sqlServerOptionsAction: sqlOptions =>
                    {
                        sqlOptions.EnableRetryOnFailure();
                    });
            });

            builder.Services.EnableApplicationInsights(configuration);
            builder.Services.AddTransient<IDbServiceFactory, DbServiceFactory>();
            builder.Services.AddTransient<IProductService, ProductService>();
            builder.Services.AddTransient<IOrderService, OrderService>();
            builder.Services.AddTransient<IShippingService, ShippingService>();
            builder.Services.AddTransient<IShippingRepository, ServiceBusShippingRepository>();
        }
    }
}
