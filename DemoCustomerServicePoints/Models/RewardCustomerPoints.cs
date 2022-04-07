﻿using System.ComponentModel.DataAnnotations;

namespace DemoCustomerServicePoints.Models
{
    public class RewardCustomerPoints
    {
        [Key]
        public string MemberId { get; set; }

        public int Points { get; set; }
    }

    public class Promotions
    {
        [Key]
        public string SKU { get; set; }
        public int Multiplier { get; set; }

        public DateTime? Start { get; set; }

        public DateTime? End { get; set; }
    }
}
