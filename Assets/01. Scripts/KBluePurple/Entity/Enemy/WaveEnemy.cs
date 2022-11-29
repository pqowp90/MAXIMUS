public class WaveEnemy : IEnemy
{
    public float Ratio;

    public WaveEnemy(int type)
    {
        EnemyType = type;
        Ratio = FormulaFunction.EnemyRatio(type);
    }

    public int EnemyType { get; set; }
}