using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MissionPanel : MonoBehaviour
{
    private Toggle _toggle;
    private Text _missionText;

    private void Awake() {
        _toggle = transform.Find("Toggle").GetComponent<Toggle>();
        _missionText = transform.Find("Text").GetComponent<Text>();
    }

    public void Init()
    {
        _toggle.isOn = false;
    }

    public void MissionComplete()
    {
        _toggle.isOn = true;
    }

    public void Reload(string text)
    {
        _missionText.text = text;
    }
}
