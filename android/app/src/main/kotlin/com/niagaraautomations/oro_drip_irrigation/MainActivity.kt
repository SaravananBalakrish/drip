package com.niagaraautomations.oroDripirrigation

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Method

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.niagaraautomations.oroDripirrigation/bluetooth"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "removeBond" -> {
                        val address = call.argument<String>("address")
                        if (address != null) {
                            result.success(removeBond(address))
                        } else {
                            result.error("INVALID_ARGUMENT", "Address is null", null)
                        }
                    }

                    "getBondState" -> {
                        val address = call.argument<String>("address")
                        if (address != null) {
                            result.success(getBondState(address))
                        } else {
                            result.error("INVALID_ARGUMENT", "Address is null", null)
                        }
                    }

                    "clearGattCache" -> {
                        val address = call.argument<String>("address")
                        if (address != null) {
                            result.success(clearGattCache(address))
                        } else {
                            result.error("INVALID_ARGUMENT", "Address is null", null)
                        }
                    }

                    "refreshDeviceCache" -> {
                        val address = call.argument<String>("address")
                        if (address != null) {
                            result.success(refreshDeviceCache(address))
                        } else {
                            result.error("INVALID_ARGUMENT", "Address is null", null)
                        }
                    }

                    "isBluetoothEnabled" -> {
                        result.success(isBluetoothEnabled())
                    }

                    "enableBluetooth" -> {
                        enableBluetooth()
                        result.success(true)
                    }

                    "disableBluetooth" -> {
                        disableBluetooth()
                        result.success(true)
                    }

                    "getConnectedDevices" -> {
                        result.success(getConnectedDevices())
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun removeBond(address: String): Boolean {
        return try {
            val adapter = BluetoothAdapter.getDefaultAdapter() ?: return false
            val device = adapter.getRemoteDevice(address)

            val method: Method = device.javaClass.getMethod("removeBond")
            method.invoke(device) as Boolean
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun getBondState(address: String): Int {
        return try {
            val adapter = BluetoothAdapter.getDefaultAdapter() ?: return 0
            val device = adapter.getRemoteDevice(address)

            when (device.bondState) {
                BluetoothDevice.BOND_NONE -> 0
                BluetoothDevice.BOND_BONDING -> 1
                BluetoothDevice.BOND_BONDED -> 2
                else -> 0
            }
        } catch (e: Exception) {
            e.printStackTrace()
            0
        }
    }

    private fun clearGattCache(address: String): Boolean {
        return try {
            val adapter = BluetoothAdapter.getDefaultAdapter() ?: return false
            val device = adapter.getRemoteDevice(address)

            val methods = listOf("refresh", "refreshDeviceCache", "clearGattCache")

            for (name in methods) {
                try {
                    val method = device.javaClass.getMethod(name)
                    method.invoke(device)
                    return true
                } catch (_: Exception) {
                }
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun refreshDeviceCache(address: String): Boolean {
        return try {
            val adapter = BluetoothAdapter.getDefaultAdapter() ?: return false
            val device = adapter.getRemoteDevice(address)

            try {
                val method = device.javaClass.getMethod("disconnect")
                method.invoke(device)
                Thread.sleep(100)
            } catch (_: Exception) {
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun isBluetoothEnabled(): Boolean {
        return BluetoothAdapter.getDefaultAdapter()?.isEnabled == true
    }

    private fun enableBluetooth() {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter != null && !adapter.isEnabled) {
            val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivity(intent)
        }
    }

    private fun disableBluetooth() {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        if (adapter != null && adapter.isEnabled) {
            adapter.disable()
        }
    }

    private fun getConnectedDevices(): List<String> {
        val list = mutableListOf<String>()

        try {
            val adapter = BluetoothAdapter.getDefaultAdapter()

            adapter?.bondedDevices?.forEach {
                list.add("${it.name}|${it.address}|${it.bondState}")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return list
    }
}