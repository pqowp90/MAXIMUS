using System.Collections;
using System.Collections.Generic;
using UnityEngine;
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
}
