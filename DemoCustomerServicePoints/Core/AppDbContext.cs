using DemoCustomerServicePoints.Models;
using Microsoft.EntityFrameworkCore;

namespace DemoCustomerServicePoints.Core
{
    public class AppDbContext : DbContext
    {
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
        {

        }

        public DbSet<RewardCustomerPoints> RewardCustomerPoints { get; set; }

        public DbSet<Promotions> Promotions { get; set; }
    }
}
