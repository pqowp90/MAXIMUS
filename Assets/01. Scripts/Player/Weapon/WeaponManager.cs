using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponManager : MonoSingleton<WeaponManager>
{
    public List<Weapon> weaponList;
    public Weapon weapon;
    private int _weaponIndex;
    private bool _isReloading = false;
    public bool IsReloading => _isReloading;

    private void Start()
    {
        if (weaponList == null) return;

        weapon = weaponList[0];
        _weaponIndex = 0;

        foreach (Weapon weapon in weaponList)
        {
            Item item = ItemManager.Instance.inventorySO.itemList.Find(x => x.item_name == weapon.bullet.bullet_name);
            weapon.bullet.bulletItem = item;
            PoolManager.CreatePool<BulletObj>($"Bullet_{weapon.bullet.bullet_name}", ItemManager.Instance.poolObj, 50);
        }
    }

    public IEnumerator WeaponReloading()
    {
        if (weapon.bullet.CheckReloaing && !_isReloading)
        {
            _isReloading = true;
            yield return new WaitForSeconds(weapon.reloadingTime);
            weapon.bullet.AmmoReload();
            _isReloading = false;
        }
    }

    public void AddBulletAmount(string bulletName, int amount = 1)
    {
        Weapon weapon = weaponList.Find(x => x.bullet.bullet_name == bulletName);
        weapon.bullet.haveAmmo += amount;
    }

    public void SwapWeapon(bool up)
    {
        _weaponIndex += up ? 1 : -1;
        if (_weaponIndex >= weaponList.Count)
            _weaponIndex = 0;
        else if (_weaponIndex < 0)
            _weaponIndex = weaponList.Count - 1;

        weapon = weaponList[_weaponIndex];
    }

}
