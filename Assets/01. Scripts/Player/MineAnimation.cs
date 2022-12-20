using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MineAnimation : MonoBehaviour
{
    private Player _player;

    private void Awake() {
        _player = GetComponentInParent<Player>();
    }

    public void Mine()
    {
        _player.Mine();
    }

    public void AnimationEnd()
    {
        _player.playerMove.animator.ResetTrigger("Mine");
    }

    public void Die()
    {
        UIManager.Instance.PauseMenu(true);
    }
}
