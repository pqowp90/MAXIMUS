using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class Billboard : MonoBehaviour, IPoolable
{
    private CanvasGroup canvasGroup;
    private Image image;
    [SerializeField]
    private Sprite defaulSprite;
    public Transform target;
    private TMP_Text tmp;
    [SerializeField]
    private float heightOffset = 1f;
    [SerializeField]
    private float scale = 5f;
    private Camera uICamera;
    public void OnPool()
    {
        if(uICamera == null)
            uICamera = UICamera.Instance.GetComponent<Camera>();
    }
    

    // Start is called before the first frame update
    private void Awake()
    {
        canvasGroup = GetComponent<CanvasGroup>();
        tmp = GetComponentInChildren<TMP_Text>();
        image = GetComponent<Image>();
    }
    public void UpdateText(string text, Sprite sprite)
    {
        tmp.text = text;
        if(sprite == null)
            image.sprite = defaulSprite;
        else
            image.sprite = sprite;
    }

    // Update is called once per frame
    void Update()
    {
        if(target)
        {
            transform.position = uICamera.WorldToScreenPoint(target.position + Vector3.up * heightOffset);
            transform.localScale = Vector3.one * scale / (Vector3.Distance(uICamera.transform.position, target.position));
            var dot = Vector3.Dot(uICamera.transform.forward, target.position - uICamera.transform.position);
            if(dot < 0)
                canvasGroup.alpha = 0f;
            else
                canvasGroup.alpha = 1f;
        }
        
    }
}
