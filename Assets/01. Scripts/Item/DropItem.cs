using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class DropItem : MonoBehaviour
{
    public Item item;

    public MeshRenderer meshRenderer;
    public MeshFilter meshFilter;
    public MeshCollider meshCollider;

    private void Awake()
    {
        meshRenderer = GetComponentInChildren<MeshRenderer>();
        meshFilter = GetComponentInChildren<MeshFilter>();
        meshCollider = GetComponentInChildren<MeshCollider>();
    }

    private void OnEnable()
    {
        Invoke("DestroyItem", ItemManager.Instance.dropTime);
    }

    private void DestroyItem()
    {
        if(gameObject.activeSelf == true)
        {
            gameObject.SetActive(false);
        }
    }
}
