using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum FactoryType
{
    Combiner,
    Foundry,
    SteelWorks,
}

[CreateAssetMenu( fileName = "FactoryRecipe", menuName = "Factorys/FactoryRecipes" )]
public class FactoryRecipesSO : ScriptableObject
{
    public FactoryType factoryType;
    public List<Item> ingredients;
    public int cost;
    public Item result;
}
