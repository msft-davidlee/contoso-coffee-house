using System.ComponentModel.DataAnnotations;

namespace DemoCustomerServicePoints.Models
{
    public class Promotions
    {
        [Key]
        public string SKU { get; set; }
        public int Multiplier { get; set; }

        public DateTime? Start { get; set; }

        public DateTime? End { get; set; }
    }
}
