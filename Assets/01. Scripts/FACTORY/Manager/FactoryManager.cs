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
        GameObject.DontDestroyOnLoad(this.gameObject);
        base.Awake();
        InputManager.Instance.KeyAction -= OnKeyAction;
        InputManager.Instance.KeyAction += OnKeyAction;
        SceneManager.sceneLoaded += OnSceneLoaded;
        InputManager.Instance.factoryMode = factoryMode;
        SceneManager.LoadScene("Factory", LoadSceneMode.Additive);
    }
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        if(scene.name == "Factory")
        {
            factory = scene.GetRootGameObjects()[0];
            factory?.SetActive(factoryMode);
        }
        overworld.SetActive(true);
        factory.SetActive(false);
        factoryMode = false;
        Cursor.lockState = (factoryMode)?CursorLockMode.Confined:CursorLockMode.Locked;
        Cursor.visible = factoryMode;
    }
    private void OnKeyAction()
    {
        if(Input.GetKeyDown(KeyCode.X))
        {
            UpdateScene();
        }
    }
    private void UpdateScene()
    {
        factoryMode = !factoryMode;
            InputManager.Instance.factoryMode = factoryMode;
            factory?.SetActive(factoryMode);
            overworld?.SetActive(!factoryMode);
            
            Cursor.lockState = (factoryMode)?CursorLockMode.Confined:CursorLockMode.Locked;
            Cursor.visible = factoryMode;
    }
}
