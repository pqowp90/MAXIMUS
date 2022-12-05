using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;

public class Player : MonoBehaviour
{
    private float _hp;
    private bool _isOpenBag;
    public ItemDB inventory;
    
    public Weapon weapon => WeaponManager.Instance.weapon;
    public Transform weaponPos;

    [SerializeField]
    private LayerMask _itemLayer;
    [SerializeField]
    private float _itemFindRadius = 1f;

    private bool _isDelay = false;

    public TMP_Text ammoText;

    [Header("Keybinds")]
    public KeyCode reloadKey = KeyCode.R;
    public KeyCode bagOpenKey = KeyCode.E;

    private void Update()
    {
        SearchItem();
        if (Input.GetButton("Fire1"))
        {
            Attak();
        }
        if(Input.GetKeyDown(reloadKey))
        {
            WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
        }

        ammoText.text = weapon.ammoText;
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

        if(!WeaponManager.Instance.IsReloading && weapon.bullet.haveAmmo > 0 && !_isDelay)
        {
            if (weapon.bullet.ammo == 0) WeaponManager.Instance.StartCoroutine(WeaponManager.Instance.WeaponReloading());
            else
            {
                weapon.bullet.ammo -= 1;

                var rigidbody = Instantiate(weapon.bullet.prefab, weaponPos);
                rigidbody.AddComponent<BulletObj>().damage = weapon.bullet.damage;
                rigidbody.GetComponent<Rigidbody>().AddForce(transform.forward * 1000);
                _isDelay = true;
                Invoke("AttackDelay", weapon.bullet.attackDelay);
            }
        }
        else
        {
            Debug.LogWarning("not ammo");
        }
    }

    private void AttackDelay()
    {
        _isDelay = false;
    }
}
