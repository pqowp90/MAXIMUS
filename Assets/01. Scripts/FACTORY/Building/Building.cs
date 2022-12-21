using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Reflection;
[Serializable]
public class RenderAndMaterial
{
    public MeshRenderer meshRenderer;
    public Material material1;
    public Material material2;
}
public class Building : MonoBehaviour, IPoolable
{
    public bool _onoff;
    public bool onoff {get{return _onoff;}set{_onoff = value; SetBuildingOnOff(value);}}

    public List<Vector2Int> range = new List<Vector2Int>();
    [SerializeField]
    public bool canJupe = false;
    public BuildingType buildingType;
    [SerializeField]
    private List<RenderAndMaterial> renderAndMaterials = new List<RenderAndMaterial>();
    [SerializeField]
    private List<GameObject> onOffGameObjects = new List<GameObject>();
    public int rotate;
    private Vector2Int pos;
    [SerializeField]
    private AudioSource noiseAudioSource;
    [SerializeField]
    public List<Recipe> ingredientItems = new List<Recipe>();
    public List<Vector2Int> rangeArray = new List<Vector2Int>();
    
    


    private void Awake() 
    {
        string myName = this.gameObject.name;
        myName = myName.Split('(')[0];
        buildingType = Enum.Parse<BuildingType>(myName);
        if(buildingType != BuildingType.ConveyorBelt || buildingType != BuildingType.Inserter)
            AudioSourceCheck();
    }
    private void AudioSourceCheck()
    {
        if(!noiseAudioSource)
        {
            noiseAudioSource = gameObject.AddComponent<AudioSource>();
            noiseAudioSource.playOnAwake = false;
            noiseAudioSource.spatialBlend = 1;
            noiseAudioSource.maxDistance = 20f;
            noiseAudioSource.outputAudioMixerGroup = FactorySoundManager.Instance.soundContaner.GetAudioMixerGroup("Factory");
        }
    }
    public void SetBuildingType(Vector2Int curPos, int curRotation)
    {
        pos = curPos;
        rotate = curRotation;

        rangeArray.Clear();
        rangeArray.AddRange(range);

        for (int i = 0; i < range.Count; i++)
        {
            rangeArray[i] = new Vector2Int(range[i].y, -range[i].x);
        }


        for (int i = 0; i < ((rotate % 4) + 3); i++)
        {
            for (int j = 0; j < range.Count; j++)
            {
                rangeArray[j] = new Vector2Int(rangeArray[j].y, -rangeArray[j].x);
            }
        }

        string typeName = buildingType.ToString();
        switch (buildingType)
        {
            case BuildingType.Foundry:
            case BuildingType.SteelWorks:
            case BuildingType.Combiner:
            typeName = "FactoryBase";
            break;
        }
        var type = GetComponent(typeName);
        if(type != null)
        {
            type.GetType().GetMethod("AddToManager").Invoke(type, new object[]{curPos, curRotation});
        }
        
        
        foreach (var item in rangeArray)
        {
            InserterManager.Instance.FindAdjacency(curPos + item);
        }
        
    }
    private void OnDrawGizmos() {
        for (int i = 0; i < rangeArray.Count; i++)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(new Vector3(rangeArray[i].x+pos.x, 0, rangeArray[i].y+pos.y), 0.1f);
        }
        
    }
    public void OnPool()
    {
        onoff = false;
        AudioSourceCheck();
        SetBuildingOnOff(onoff);
        IngredientUI.Instance.SetIngredient(ingredientItems, true);
    }
    private void SetBuildingOnOff(bool _onoff)
    {
        if(_onoff)
        {
            if(noiseAudioSource == null){
                noiseAudioSource.clip = FactorySoundManager.Instance.soundContaner.GetAudioClip("FactoryNoise1");
                noiseAudioSource.volume = UnityEngine.Random.Range(0.3f, 0.32f);
                noiseAudioSource.Play();
                noiseAudioSource.loop = true;
            }

            foreach (var item in renderAndMaterials)
            {
                item.meshRenderer.material = item.material1;
            }
            
        }
        else{
            if(noiseAudioSource == null)
                if(noiseAudioSource.isPlaying)
                    noiseAudioSource.Stop();
            foreach (var item in renderAndMaterials)
            {
                item.meshRenderer.material = item.material2;
            }
        }
        foreach (var item in onOffGameObjects)
        {
            item.SetActive(onoff);
        }
    }
}
