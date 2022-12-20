using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletManager : MonoSingleton<BulletManager>
{
    public List<Bullet> bulletList;
    public Bullet currentBullet;
    private int _bulletIndex;
    public int BulletIndex => _bulletIndex;

    private void Start()
    {
        if (bulletList == null) return;

        currentBullet = bulletList[0];
        _bulletIndex = 0;

        foreach (Bullet currentBullet in bulletList)
        {
            PoolManager.CreatePool<BulletObj>($"Bullet_{currentBullet.bulletItem.item_name}", ItemManager.Instance.poolObj, 50);
        }
    }
    
    public void SwapBullet(bool up)
    {
        _bulletIndex += up ? -1 : 1;
        if (_bulletIndex >= bulletList.Count)
            _bulletIndex = 0;
        else if (_bulletIndex < 0)
            _bulletIndex = bulletList.Count - 1;

        currentBullet = bulletList[_bulletIndex];
        UIManager.Instance.SlotChange();
    }

}
