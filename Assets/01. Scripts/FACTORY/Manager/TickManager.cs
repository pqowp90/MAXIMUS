using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TickManager : MonoSingleton<TickManager>
{
    public float tickTime{get;private set;}
    [SerializeField]
    private float TickTime;
    [SerializeField]
    private float timmer = 0f;
    private bool isGo = true;
    // Start is called before the first frame update
    public override void Awake()
    {
        base.Awake();
        tickTime = TickTime;
    }
    public void GoTick(bool _isGo)
    {
        isGo = _isGo;
    }

    // Update is called once per frame
    void Update()
    {
        TickTimeSpand();
    }
    private void TickTimeSpand()
    {
        if(isGo==false)
            return;
        timmer += Time.deltaTime;
        if(timmer >= tickTime)
        {
            timmer -= tickTime;
            FactoryBaseManager.Instance.Use();
            InserterManager.Instance.Use();
            ConveyorBeltManager.Instance.Use();
            DropperManager.Instance.Use();
        }
    }
}
