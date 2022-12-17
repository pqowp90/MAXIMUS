using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class Vignetting : MonoBehaviour, IPoolable
{
    public Image image;
    public Color redColor;
    public Color greenColor;
    public bool isRed = true;
    public void OnPool()
    {
        image = GetComponent<Image>();
        image.DOFade(0.5f, 0f);
        if(isRed)
            image.color = redColor;
        else
            image.color = greenColor;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
