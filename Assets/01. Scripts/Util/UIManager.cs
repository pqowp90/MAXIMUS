using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;
using DG.Tweening;
using UnityEngine.UI;
using JetBrains.Annotations;

public class UIManager : MonoSingleton<UIManager>
{
    [SerializeField]
    private GameObject damagePopup;
    [SerializeField] private TMP_Text messageText;

    #region Item Enter UI Popup

    public List<GameObject> items = new List<GameObject>();
    [SerializeField] private Canvas _itemCanvas;

    #endregion

    public GameObject player;

    public override void Awake()
    {
        base.Awake();
        player = FindObjectOfType<Player>().gameObject;
    }

    private void Start()
    {
        PoolManager.CreatePool<ItemEnterUI>("ItemEnterUIPrefab", _itemCanvas.gameObject, 10);
    }

    public void Popup(Transform pos, string text, bool isPlayer = false)
    {
        var pop = Instantiate(damagePopup);
        pop.transform.position = new Vector3(pos.position.x, pos.position.y + 1f, pos.position.z);
        pop.transform.LookAt(player.transform);
        pop.transform.DORotate(new Vector3(0, pop.transform.rotation.y, 0), 0);

        TMP_Text popText = pop.GetComponent<TMP_Text>();
        popText.text = text;
        if(isPlayer)
        {
            popText.color = Color.white;
            popText.fontSize = 3f;
        }
    }

    public void ItemEnter(Item item, int amount)
    {
        var ui = PoolManager.GetItem<ItemEnterUI>("ItemEnterUIPrefab");
        ui.itemIcon.sprite = item.icon;
        ui.amountText.text = $"+{amount}";

        items.Add(ui.gameObject);
        ui.transform.position = new Vector3(-130, 130);

        items[items.Count - 1].transform.DOMoveX(200, 0.2f);
        int cnt = items.Count - 1;
        for(int i = 0; i < items.Count - 1; i++)
        {
            items[i].transform.DOMoveY(80 * cnt-- + 130, 0.7f);
        }
    }

    public void Message(string text)
    {
        if(messageText.color.a == 1) messageText.DOFade(0, 0);
        messageText.text = text;
        messageText.DOFade(1, 0.3f);
    }

    public void MessageDown()
    {
        if(messageText.color.a == 1)
            messageText.DOFade(0, 0.3f);
    }
}
