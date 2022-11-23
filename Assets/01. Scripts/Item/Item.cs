using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ITEM_TYPE : int
{
    Item,
    Potion,
    Helmet,
    Body,
    Patns,
    Botts,
    Gun
}

[CreateAssetMenu(fileName = "New Item", menuName = "Inventory/Items/Item")]
public class Item : ScriptableObject
{
    [Header("기본속성")]
    public string item_name = "";
    public int item_ID = -1;
    public ITEM_TYPE item_type = ITEM_TYPE.Item;
    public bool isStackable = false;

    [Header("이미지")]
    public Sprite icon;
    public GameObject modelPrefab;

    [Header("설명")]
    [TextArea(15, 20)]
    public string explain;
}
