using UnityEngine;

//[ExecuteAlways]
public class LightingManager : MonoBehaviour
{
    //Scene References
    [SerializeField] private Light DirectionalLight;
    [SerializeField] private LightingPreset Preset;
    //Variables
    [SerializeField, Range(0, 100)] private float TimeOfDay;



    private void Update()
    {
        if (Preset == null)
            return;

        //(Replace with a reference to the game time)
        if(!InputManager.Instance.factoryMode){
            TimeOfDay += Time.deltaTime;
            TimeOfDay %= 100f; //Modulus to ensure always between 0-24
        }
        UpdateLighting(TimeOfDay / 100f);
    }


    private void UpdateLighting(float timePercent)
    {
        //Set ambient and fog
        RenderSettings.ambientLight = Preset.AmbientColor.Evaluate(timePercent);
        RenderSettings.fogColor = Preset.FogColor.Evaluate(timePercent);

        //If the directional light is set then rotate and set it's color, I actually rarely use the rotation because it casts tall shadows unless you clamp the value
        if (DirectionalLight != null)
        {
            DirectionalLight.color = Preset.DirectionalColor.Evaluate(timePercent);

            DirectionalLight.transform.localRotation = Quaternion.Euler(new Vector3((timePercent * 360f) - 90f, 170f, 0));
            if(Application.isPlaying)
            {
                if (DirectionalLight.transform.rotation.x < 0)
                {
                    if (DayCycleManager.Instance.currentCycle == DayCycleManager.Cycle.Day)
                        DayCycleManager.Instance.ChangeCycle(DayCycleManager.Cycle.Night);
                }
                else
                {
                    if (DayCycleManager.Instance.currentCycle == DayCycleManager.Cycle.Night)
                        DayCycleManager.Instance.ChangeCycle(DayCycleManager.Cycle.Day);
                }
            }
           
        }

    }



    //Try to find a directional light to use if we haven't set one
    private void OnValidate()
    {
        if (DirectionalLight != null)
            return;

        //Search for lighting tab sun
        if (RenderSettings.sun != null)
        {
            DirectionalLight = RenderSettings.sun;
        }
        //Search scene for light that fits criteria (directional)
        else
        {
            Light[] lights = GameObject.FindObjectsOfType<Light>();
            foreach (Light light in lights)
            {
                if (light.type == LightType.Directional)
                {
                    DirectionalLight = light;
                    return;
                }
            }
        }
    }

}
