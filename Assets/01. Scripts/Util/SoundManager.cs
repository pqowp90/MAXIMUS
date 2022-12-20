using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SoundType
{
    UI,
    EFFECT,
    FACTORY,
    BACKGROUND
}

public class SoundManager : MonoSingleton<SoundManager>
{
    private AudioSource _audio;

    public override void Awake() {
        _audio = GetComponent<AudioSource>();
    }

    public void PlayClip(AudioClip clip)
    {
        _audio.clip = clip;
        _audio.PlayOneShot(clip);
    }
}
