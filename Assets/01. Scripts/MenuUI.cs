using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class MenuUi : MonoSingleton<MenuUi>
{
    private GameObject option;
    public AudioMixer audioMixer{get;private set;}
    public bool isOption=false;
    public override void Awake(){
        option=Instantiate(Resources.Load<GameObject>("Option"));
        audioMixer = Resources.Load<AudioMixer>("AllMixer");
        option.transform.SetParent(transform);
    }
    public void Option(){
        option.SetActive(!option.activeSelf);
        
    }
    
}