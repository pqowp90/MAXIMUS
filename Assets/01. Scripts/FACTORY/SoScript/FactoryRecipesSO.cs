using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public enum FactoryType
{
    Combiner,
    Foundry,
    SteelWorks,
}
[System.Serializable]
public class Recipe
{
    public Item item;
    public int count;
    public Recipe(Item _item, int _count)
    {
        item = _item;
        count = _count;
    }
}

[CreateAssetMenu( fileName = "FactoryRecipe", menuName = "Factorys/FactoryRecipes" )]
public class FactoryRecipesSO : ScriptableObject
{
    public string recipeName;
    public FactoryType factoryType;
    public List<Recipe> ingredients;
    public int cost;
    public Recipe result;
}
