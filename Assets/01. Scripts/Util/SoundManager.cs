// using System.Collections;
// using System.Collections.Generic;
// using UnityEngine;

<<<<<<< HEAD
// public class SoundManager : MonoBehaviour
// {
    
// }
=======
public class SoundManager : MonoSingleton<SoundManager>
{
    private AudioSource _audio;

    public override void Awake() {
        _audio = GetComponent<AudioSource>();
    }

    public void PlayClip(AudioClip clip)
    {
        _audio.clip = clip;
        _audio.Play();
    }
}
>>>>>>> 780e61a0ba0df4ccac9980ad58ed178330308ee7
