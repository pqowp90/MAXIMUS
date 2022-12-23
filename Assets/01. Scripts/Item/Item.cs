using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ITEM_TYPE : int
{
    Item,
    Potion,
    Gun,
    Bullet,
    Ore,
    Ingredient,
}

[CreateAssetMenu(fileName = "New Item", menuName = "Inventory/Items/Item")]
public class Item : ScriptableObject
{
    [Header("아이템 정보")]
    public string item_name = "";
    public string korian_name = "";
    public int item_ID = -1;
    public ITEM_TYPE item_type = ITEM_TYPE.Item;
    public bool isStackable = false;
    public int amount = 0;
    public Sprite icon = null;

    [Header("텍스쳐")]
    public Material material;
    public Mesh mesh;

    [Header("설명")]
    [TextArea(15, 20)]
    public string explain;
    public Vector3 meshScale = Vector3.one;
    public Vector3 meshRotation;
}
