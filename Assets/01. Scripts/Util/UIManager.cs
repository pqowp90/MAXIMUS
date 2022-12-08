using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;

public class UIManager : MonoSingleton<UIManager>
{
    [SerializeField]
    private GameObject damagePopup;

    public GameObject player;

    private void Awake()
    {
        player = FindObjectOfType<Player>().gameObject;
    }

    public void Popup(Transform pos, string text)
    {
        var pop = Instantiate(damagePopup);
        pop.transform.position = new Vector3(pos.position.x, pos.position.y + 1f, pos.position.z);
        pop.GetComponent<TMP_Text>().text = text;
    }
}
