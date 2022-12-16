using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(fileName = "New Ore", menuName = "Wave/Ore")]
public class OreSO : ScriptableObject
{
    [Header("Name")]
    public string oreName;

    [Header("Resource")]
    public Mesh mesh;
    public Material material;
    
    [Header("Drop Amount")]
    public int dropMinAmount;
    public int dropMaxAmount;

    [Header("Health")]
    public int maxHealth;

    [Header("Drop Item")]
    public Item dropItem;
}
