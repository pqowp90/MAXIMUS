using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TickManager : MonoSingleton<TickManager>
{
    [SerializeField]
    private float tickTime = 1f;
    [SerializeField]
    private float timmer = 0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        timmer += Time.deltaTime;
        if(timmer >= tickTime)
        {
            timmer -= tickTime;
            InserterManager.Instance.Use();
            ConveyorBeltManager.Instance.Use();
            DropperManager.Instance.Use();
            FactoryBaseManager.Instance.Use();
        }
    }
}
