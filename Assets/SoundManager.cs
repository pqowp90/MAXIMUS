using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FactorySoundManager : MonoSingleton<FactorySoundManager>
{
    public SoundContaner soundContaner;
    public override void Awake() {
        soundContaner = Resources.Load("SoundContaner") as SoundContaner;
    }
}
