using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Range : MonoBehaviour, IPoolable
{
    [SerializeField]
    private Material materialGreen;
    [SerializeField]
    private Material materialRed;
    private MeshRenderer meshRenderer;
    public void OnPool()
    {
        meshRenderer = GetComponentInChildren<MeshRenderer>();
    }

    public void ChangeMaterial(bool red)
    {
        if(!red)
        {
            meshRenderer.material = materialGreen;
        }
        else
            meshRenderer.material = materialRed;
    }


}
