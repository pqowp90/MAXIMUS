using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public enum SPACE_ITEM
{
    ENGINE,
    BATTERY,
    STIFFENER
}

public class MissionManager : MonoSingleton<MissionManager>
{
    [SerializeField] private List<MissionPanel> _missionPanel;

    private int _engineAmount = 0;
    private int _batteryAmount = 0;
    private int _striffenerAmount = 0;

    private bool _engineComplete = false;
    private bool _batteryComplete = false;
    private bool _striffenerComplete = false;

    public void AddItem(SPACE_ITEM item, int amount)
    {
        switch(item)
        {
            case SPACE_ITEM.ENGINE:
                _engineAmount += amount;
                if(_engineAmount >= 10)
                {
                    _engineComplete = true;
                    _engineAmount = 10;
                    _missionPanel[0].MissionComplete();
                }
                _missionPanel[0].Reload($"엔진 수리하기 ( {_striffenerAmount}/10 )");
                break;

            case SPACE_ITEM.BATTERY:
                _batteryAmount += amount;
                if(_batteryAmount >= 20)
                {
                    _batteryComplete = true;
                    _batteryAmount = 20;
                    _missionPanel[1].MissionComplete();
                }
                _missionPanel[1].Reload($"배터리 넣기 ( {_striffenerAmount}/20 )");
                break;

            case SPACE_ITEM.STIFFENER:
                _striffenerAmount += amount;
                if(_striffenerAmount >= 50)
                {
                    _striffenerComplete = true;
                    _striffenerAmount = 50;
                    _missionPanel[2].MissionComplete();
                }
                _missionPanel[2].Reload($"보강재 조립하기 ( {_striffenerAmount}/50 )");
                break;
        }

        if(_engineComplete && _batteryComplete && _striffenerComplete)
        {
            _missionPanel.RemoveAt(1);
            _missionPanel.RemoveAt(2);
            _missionPanel[0].Init();
            _missionPanel[0].Reload("행성 탈출하기");
        }
    }
}
