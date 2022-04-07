using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DemoCore
{
    public static class Extensions
    {
        public static string GetConnectionString(this IConfiguration configuration)
        {
            var dbDataSource = configuration["DbSource"];
            if (!string.IsNullOrEmpty(dbDataSource))
            {
                var dbName = configuration["DbName"];
                var userId = configuration["DbUserId"];
                var dbPassword = configuration["DbPassword"];
                return $"Data Source={dbDataSource};Initial Catalog={dbName}; User Id={userId};Password={dbPassword}";
            }

            string connectionString = configuration["DbConnectionString"];
            if (connectionString.StartsWith("FilePath="))
            {
                string filePath = connectionString.Split('=')[1];
                return File.ReadAllText(filePath);
            }

            return connectionString;
        }

        public static void EnableApplicationInsights(this IServiceCollection services, IConfiguration configuration)
        {
            // See: https://github.com/microsoft/ApplicationInsights-Kubernetes
            var appInsightsInstrumentationKey = configuration["AppInsightsInstrumentationKey"];
            if (!string.IsNullOrEmpty(appInsightsInstrumentationKey))
            {
                services.AddApplicationInsightsTelemetry(appInsightsInstrumentationKey);
                services.AddApplicationInsightsKubernetesEnricher();
            }
        }
    }
}