using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class HPBar : MonoBehaviour
{
    private Slider hpSlider;
     
    public float MinimumValue
    {
        get => hpSlider.minValue;
        set
        {
            hpSlider.minValue = value;
        }
    }
     
    public float MaximumValue
    {
        get => hpSlider.maxValue;
        set => hpSlider.maxValue = value;
    }
     
    public float Value
    {
        get => hpSlider.value;
        set => hpSlider.DOValue(value, .01f);
    }
     
    private void Awake()
    {
        hpSlider = gameObject.GetComponentInChildren<Slider>();
    }

    public void Init(float value)
    {
        Value = value;
        MaximumValue = value;
        MinimumValue = 0;
    }
}
