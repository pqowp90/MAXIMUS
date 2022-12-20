using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

public class SliderSound : MonoBehaviour
{
    private Slider slider;
    private AudioMixer audioMixer;

    [SerializeField]
    private Text valueText,nameText;
    private void Start(){
        slider = GetComponentInChildren<Slider>();
        audioMixer = MenuUi.Instance.audioMixer;
        ValueChanged(PlayerPrefs.GetFloat(nameText.text, 0f));
        slider.value = PlayerPrefs.GetFloat(nameText.text, 0f);
    }
    public void ValueChanged(float value){
        valueText.text = string.Format("{0}",(int)(100-(-value)/4*10f));
        
        if(value == -40f) audioMixer.SetFloat(nameText.text,-80);
        else audioMixer.SetFloat(nameText.text, value);
        PlayerPrefs.SetFloat(nameText.text, value);
    }

}