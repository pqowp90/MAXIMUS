using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class FactoryBase : MonoBehaviour, BuildingTransfrom
{
    private AudioSource audioSource;
    private int rotation;
    private int Rotation{set{rotation = (value%4 + 4) % 4;}get{return rotation;}}
    public Vector2Int pos;
    public List<FactoryRecipesSO> factoryRecipesSO = new List<FactoryRecipesSO>();
    public FactoryRecipesSO curRecipe;
    private Billboard billboard;
    public List<ItemSpace> inputSpaces = new List<ItemSpace>();
    public ItemSpace outPutSpace;
    public int productionProgress;
    public Action incressProductionProgress;
    
    
    private void Awake() {
        audioSource = GetComponent<AudioSource>();
        audioSource.outputAudioMixerGroup = FactorySoundManager.Instance.soundContaner.GetAudioMixerGroup("Factory");
        outPutSpace = gameObject.AddComponent<ItemSpace>();
        outPutSpace.Reset();
        outPutSpace.canIn = false;
        outPutSpace.canOut = true;
        outPutSpace.spaceType = SpaceType.Multy;
        for (int i = 0; i < 3; i++)
        {
            inputSpaces.Add(gameObject.AddComponent<ItemSpace>());
            inputSpaces[i].Reset();
            inputSpaces[i].canOut = false;
            inputSpaces[i].canIn = true;
            inputSpaces[i].spaceType = SpaceType.Multy;
        }
        
    }

    public void SetRecipe(FactoryRecipesSO _recipe)
    {
        curRecipe = _recipe;
        outPutSpace.connectSO = _recipe.result.item;
        foreach (var item in inputSpaces)
        {
            item.Reset();
        }
        for (int i = 0; i < _recipe.ingredients.Count; i++)
        {
            inputSpaces[i].connectSO = _recipe.ingredients[i].item;
        }
        FactoryUIManager.Instance.SetFactoryUI(this);
        GetComponent<Building>().onoff = true;
    }
    private void PlaySound(string _name)
    {
        audioSource.pitch = UnityEngine.Random.Range(1f, 1.2f);
        audioSource.volume = UnityEngine.Random.Range(0.1f, 0.12f);
        audioSource.PlayOneShot(FactorySoundManager.Instance.soundContaner.GetAudioClip(_name));
    }
    public void OneTick()
    {
        
        if(curRecipe == null) return;
        productionProgress++;
        if(incressProductionProgress != null)
            PlaySound("FactoryImpactSound");
        if(productionProgress >= curRecipe.cost)
        {
            foreach (var recipe in curRecipe.ingredients)
            {
                ItemSpace itemSpace = inputSpaces.Find(x => x.connectSO == recipe.item);
                itemSpace.count -= recipe.count;
            }
            productionProgress = 0;
            outPutSpace.count+=curRecipe.result.count;
        }
        incressProductionProgress?.Invoke();
    }
    
    public void AddToManager(Vector2Int curPos, int curRotation)
    {
        FactoryBaseManager.Instance.Build(curPos, curRotation, this);
    }

    public void SetTransform(int _rotation, Vector2Int _pos)
    {
        Rotation = _rotation;
        pos = _pos;

        billboard = PoolManager.GetItem<Billboard>("Billboard");
        if(billboard != null)
            billboard.target = transform;
    }
    private void OnDisable() {
        if(billboard != null)
            billboard.gameObject.SetActive(false);
    }

    

    void Update()
    {
        if(billboard == null) return;
        if(curRecipe != null)
            billboard.UpdateText("", curRecipe.result.item.icon);
        else{
            billboard.UpdateText("None", null);
        }
    }
    public void DeleteBuilding()
    {
        IngredientUI.Instance.DeleteBuilding(outPutSpace);
        foreach (var item in inputSpaces)
        {
            IngredientUI.Instance.DeleteBuilding(item);
        }
        FactoryBaseManager.Instance.Destroy(this);
    }
}
