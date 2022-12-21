using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OverworldScene : MonoBehaviour
{
    [SerializeField] private AudioClip _dayAudio;
    [SerializeField] private AudioClip _nightAudio;

    private void Start() {
        SoundManager.Instance.PlayClip(SoundType.BACKGROUND, _dayAudio);
    }
}
