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
    [Header("�⺻�Ӽ�")]
    public string item_name = "";
    public int item_ID = -1;
    public ITEM_TYPE item_type = ITEM_TYPE.Item;
    public bool isStackable = false;
    public int amount = 0;

    [Header("�̹���")]
    public Material material;
    public Mesh mesh;

    [Header("����")]
    [TextArea(15, 20)]
    public string explain;
}
