using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class FactoryManager : MonoSingleton<FactoryManager>
{
    [SerializeField]
    public GameObject factory;
    [SerializeField]
    private GameObject overworld;
    
    public bool factoryMode = false;
    
    public override void Awake() {
        InputManager.Instance.factoryMode = factoryMode;
        base.Awake();
        InputManager.Instance.KeyAction -= OnKeyAction;
        InputManager.Instance.KeyAction += OnKeyAction;
        SceneManager.sceneLoaded += OnSceneLoaded;
        SceneManager.LoadScene("Factory", LoadSceneMode.Additive);
    }
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        if(scene.name == "Factory")
        {
            factory = scene.GetRootGameObjects()[0];
            factory.SetActive(factoryMode);
        }
    }
    private void OnKeyAction()
    {
        if(Input.GetKeyDown(KeyCode.X))
        {
            factoryMode = !factoryMode;
            factory.SetActive(factoryMode);
            overworld.SetActive(!factoryMode);
            
            Cursor.lockState = (factoryMode)?CursorLockMode.Confined:CursorLockMode.Locked;
            Cursor.visible = factoryMode;
        }
    }
}
