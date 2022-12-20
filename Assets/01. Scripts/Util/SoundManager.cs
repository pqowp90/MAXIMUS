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
    [SerializeField] private AudioSource _uiAudio;
    [SerializeField] private AudioSource _effectAudio;
    [SerializeField] private AudioSource _factoryAudio;
    [SerializeField] private AudioSource _bgmAudio;

    public void PlayClip(SoundType type, AudioClip clip)
    {
        AudioSource source = null;
        switch(type)
        {
            case SoundType.UI:
                source = _uiAudio;
                break;
            case SoundType.EFFECT:
                source = _effectAudio;
                break;
            case SoundType.FACTORY:
                source = _factoryAudio;
                break;
            case SoundType.BACKGROUND:
                source = _bgmAudio;
                break;
        }

        source.clip = clip;
        source.PlayOneShot(clip);
    }
}
