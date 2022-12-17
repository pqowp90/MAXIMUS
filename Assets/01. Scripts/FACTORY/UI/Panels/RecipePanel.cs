using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class RecipePanel : MonoBehaviour, IPoolable
{
    public ItemPanel resultPanel;
    public List<ItemPanel> inputPanelList = new List<ItemPanel>();
    [SerializeField]
    private GameObject recipePanelParent;
    [SerializeField]
    private TMP_Text costText;
    [SerializeField]
    public Button button;

    public void OnPool()
    {
        resultPanel.ResetPanel();
        ClearRecipe();
    }

    public void SetRecipe(FactoryRecipesSO recipe)
    {
        costText.text = recipe.cost.ToString();
        resultPanel.SetItemRecipe(recipe.result.item, recipe.result.count);
        for(int i = 0; i < recipe.ingredients.Count; i++)
        {
            ItemPanel itemPanel = FactoryUIManager.Instance.GetItemUI(recipePanelParent);
            itemPanel.SetItemRecipe(recipe.ingredients[i].item, recipe.ingredients[i].count);
            inputPanelList.Add(itemPanel);
        }
    }
    public void ClearRecipe()
    {
        for(int i = 0; i < inputPanelList.Count; i++)
        {
            FactoryUIManager.Instance.GiveBackItemUI(inputPanelList[i].gameObject);
        }
        inputPanelList.Clear();
    }
}
