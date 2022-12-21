using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

[DontDestroyOnLoad]
public class FactoryManager : MonoSingleton<FactoryManager>
{
    [SerializeField]
    public GameObject factory;
    [SerializeField]
    private GameObject overworld;
    
    public bool factoryMode = false;

    
    public override void Awake() {
        base.Awake();
        // InputManager.Instance.KeyAction -= OnKeyAction;
        // InputManager.Instance.KeyAction += OnKeyAction;
        SceneManager.sceneLoaded += OnSceneLoaded;
        InputManager.Instance.factoryMode = factoryMode;
        
        
        
    }
    private void Update()
    {
        OnKeyAction();
    }

    private void Start() {
        SceneManager.LoadScene("Factory", LoadSceneMode.Additive);
    }
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        factoryMode = false;
        if(scene.name == "Factory")
        {
            factory = scene.GetRootGameObjects()[0];
            factory?.SetActive(factoryMode);
            InputManager.Instance.factoryCamera = scene.GetRootGameObjects()[1].transform.GetChild(0).gameObject;
            InputManager.Instance.SetMode();
        }
        overworld.SetActive(true);
        factory.SetActive(false);
        Cursor.lockState = (factoryMode)?CursorLockMode.Confined:CursorLockMode.Locked;
        Cursor.visible = factoryMode;

    }
    private void OnKeyAction()
    {
        if(Input.GetKeyDown(KeyCode.X))
        {
            
            GoBackPack.Instance.GoBag();
        }
    }
    public void UpdateScene()
    {
        factoryMode = !factoryMode;
        InputManager.Instance.factoryMode = factoryMode;
        factory?.SetActive(factoryMode);
        overworld?.SetActive(!factoryMode);
        
        Cursor.lockState = (factoryMode)?CursorLockMode.Confined:CursorLockMode.Locked;
        Cursor.visible = factoryMode;

    }
}
