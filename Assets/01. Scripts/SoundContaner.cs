using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

[System.Serializable]
public class SoundClip
{
    [SerializeField]
    public string name;
    [SerializeField]
    public AudioClip audioClips;
}
[CreateAssetMenu(fileName = "SoundContaner", menuName = "Sound")]
public class SoundContaner : ScriptableObject
{
    [SerializeField]
    List<SoundClip> audioClips = new List<SoundClip>();
    [SerializeField]
    List<AudioMixerGroup> audioMixerGroups = new List<AudioMixerGroup>();
    public AudioClip GetAudioClip(string name)
    {
        foreach (var item in audioClips)
        {
            if(item.name == name)
            {
                return item.audioClips;
            }
        }
        return null;
    }

    public AudioMixerGroup GetAudioMixerGroup(string v)
    {
        foreach (var item in audioMixerGroups)
        {
            if(item.name == name)
            {
                return item;
            }
        }
        return null;
    }
}
