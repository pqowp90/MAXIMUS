using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponManager : MonoSingleton<WeaponManager>
{
    public List<Weapon> weaponList;
    public Weapon weapon;
    private bool _isReloading = false;
    public bool IsReloading => _isReloading;

    private void Start()
    {
        if (weaponList == null) return;

        foreach(Weapon weapon in weaponList)
        {
            weapon.bullet.haveAmmo = ItemManager.Instance.inventorySO.itemList.Find(x => x.item_name == weapon.bullet.bullet_name).amount;
        }

        if(weapon == null)
        {
            weapon = weaponList[0];
        }
    }

    public IEnumerator WeaponReloading()
    {
        if (weapon.bullet.CheckReloaing)
        {
            _isReloading = true;
            yield return new WaitForSeconds(weapon.reloadingTime);
            weapon.bullet.AmmoReload();
            _isReloading = false;
        }
    }

    public void AddBulletAmount(string bulletName, int amount = 1)
    {
        foreach(Weapon weapon in weaponList)
        {
            if(weapon.bullet.bullet_name == bulletName)
            {
                weapon.bullet.ammo += amount;
                return;
            }
        }

        Debug.LogWarning($"{bulletName} Bullet is not found!");
    }
}
