using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitleScene : MonoBehaviour
{
    [SerializeField] private AudioClip _bgm;
    private void Start() {
        SoundManager.Instance.PlayClip(SoundType.BACKGROUND, _bgm);
    }
}
