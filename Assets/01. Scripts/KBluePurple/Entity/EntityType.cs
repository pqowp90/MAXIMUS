using System;

[Flags]
public enum EntityType
{
    Enemy = 1 << 0,
    Player = 1 << 1,
    Structure = 1 << 2,
    Chest = 1 << 3,
    All = Enemy | Player | Structure | Chest
}