using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    private float _hp;
    private bool _isOpenBag;
    public ItemDB inventory;
    
    public Weapon weapon => WeaponManager.Instance.weapon;

    [SerializeField]
    private LayerMask _itemLayer;
    [SerializeField]
    private float _itemFindRadius = 1f;

    private void Update()
    {
        SearchItem();
        if(Input.GetMouseButton(0))
        {
            Attak();
        }
    }

    private void SearchItem()
    {
        Collider[] _item = Physics.OverlapSphere(transform.position, _itemFindRadius, _itemLayer);
        if (_item.Length > 0)
        {
            foreach (var item in _item)
            {
                ItemManager.Instance.GetItem(item.GetComponentInParent<DropItem>().item);
                item.transform.parent.gameObject.SetActive(false);
            }
        }
    }

    private void Attak()
    {
        if (weapon == null) return;

        if(!WeaponManager.Instance.IsReloading && weapon.bullet.haveAmmo > 0)
        {
            if (weapon.bullet.ammo == 0) WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
            else
            {
                
            }
        }
    }
}
