using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class DropItem : MonoBehaviour, IPoolable
{
    public Item item;

    public MeshRenderer meshRenderer;
    public MeshFilter meshFilter;
    public MeshCollider meshCollider;
    public Rigidbody rb;
    public bool isEntering = false;

    private void Awake()
    {
        meshRenderer = GetComponentInChildren<MeshRenderer>();
        meshFilter = GetComponentInChildren<MeshFilter>();
        meshCollider = GetComponentInChildren<MeshCollider>();
        rb = GetComponent<Rigidbody>();
    }

    private void OnDisable() {
        OffRb(false);
    }
    public void OffRb(bool onoff)
    {
        rb.isKinematic = onoff;
    }

    private void DestroyItem()
    {
        if(gameObject.activeSelf == true && !rb.isKinematic)
        {
            gameObject.SetActive(false);
        }
    }

    public void OnPool()
    {
        Invoke("DestroyItem", ItemManager.Instance.dropTime);
        SetScale(Vector3.one);
        SetRotation(Quaternion.identity);
    }

    public void SetScale(Vector3 scale)
    {
        transform.localScale = scale;
    }

    public void SetRotation(Vector3 rotation)
    {
        transform.rotation = Quaternion.Euler(rotation);
    }

    public void SetRotation(Quaternion rotation)
    {
        transform.rotation = rotation;
    }
}
