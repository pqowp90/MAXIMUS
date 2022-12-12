using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FactoryManager : MonoSingleton<FactoryManager>
{
    [SerializeField]
    private GameObject factory;
    [SerializeField]
    private GameObject overworld;
    private bool factoryMode = false;
    private void Update() {
        if(factoryMode)
        {
            if(Input.GetKeyDown(KeyCode.Escape))
            {
                factoryMode = false;
                factory.SetActive(false);
                overworld.SetActive(true);
            }
        }
        else
        {
            if(Input.GetKeyDown(KeyCode.F))
            {
                factoryMode = true;
                factory.SetActive(true);
                overworld.SetActive(false);
            }
        }
    }
}
