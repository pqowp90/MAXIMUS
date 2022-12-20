using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IngredientUI : MonoSingleton<IngredientUI>
{
    private List<ItemPanel> itemPanels = new List<ItemPanel>();
    public void SetIngredient(List<Recipe> ingredients)
    {
        foreach (var item in ingredients)
        {
            ItemPanel _itemPanel = itemPanels.Find(x => x.item == item.item);
            if(_itemPanel)
                _itemPanel.SetItemRecipe(item.item, item.count+int.Parse(_itemPanel.itemText.text));
            else
                itemPanels.Add(FactoryUIManager.Instance.GetItemUI(transform.gameObject).SetItemRecipe(item.item, item.count));
        }
    }
    public void ClearIngredient()
    {
        foreach (ItemPanel item in itemPanels)
        {
            ItemManager.Instance.TakeItem(item.item.item_ID, int.Parse(item.itemText.text));
            item.itemText.text = "";
            FactoryUIManager.Instance.GiveBackItemUI(item.gameObject);
        }
        itemPanels.Clear();
    }
}
