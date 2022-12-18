using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoSingleton<SoundManager>
{
    public SoundContaner soundContaner;
    public override void Awake() {
        soundContaner = Resources.Load("SoundContaner") as SoundContaner;
    }
}
