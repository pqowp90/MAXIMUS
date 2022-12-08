using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;
using DG.Tweening;

public class UIManager : MonoSingleton<UIManager>
{
    [SerializeField]
    private GameObject damagePopup;

    public GameObject player;

    void Awake()
    {
        player = FindObjectOfType<Player>().gameObject;
    }

    public void Popup(Transform pos, string text)
    {
        var pop = Instantiate(damagePopup);
        pop.transform.position = new Vector3(pos.position.x, pos.position.y + 1f, pos.position.z);
        pop.transform.LookAt(player.transform);
        pop.transform.DORotate(new Vector3(0, pop.transform.rotation.y, 0), 0);
        pop.GetComponent<TMP_Text>().text = text;
    }
}
