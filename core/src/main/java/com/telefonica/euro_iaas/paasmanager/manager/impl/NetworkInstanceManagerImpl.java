/**
 * (c) Copyright 2013 Telefonica, I+D. Printed in Spain (Europe). All Rights Reserved.<br>
 * The copyright to the software program(s) is property of Telefonica I+D. The program(s) may be used and or copied only
 * with the express written consent of Telefonica I+D or in accordance with the terms and conditions stipulated in the
 * agreement/contract under which the program(s) have been supplied.
 */

package com.telefonica.euro_iaas.paasmanager.manager.impl;

import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;

import com.telefonica.euro_iaas.commons.dao.AlreadyExistsEntityException;
import com.telefonica.euro_iaas.commons.dao.EntityNotFoundException;
import com.telefonica.euro_iaas.commons.dao.InvalidEntityException;
import com.telefonica.euro_iaas.paasmanager.claudia.NetworkClient;
import com.telefonica.euro_iaas.paasmanager.dao.NetworkInstanceDao;
import com.telefonica.euro_iaas.paasmanager.exception.InfrastructureException;
import com.telefonica.euro_iaas.paasmanager.manager.NetworkInstanceManager;
import com.telefonica.euro_iaas.paasmanager.manager.RouterManager;
import com.telefonica.euro_iaas.paasmanager.manager.SubNetworkInstanceManager;
import com.telefonica.euro_iaas.paasmanager.model.ClaudiaData;
import com.telefonica.euro_iaas.paasmanager.model.NetworkInstance;
import com.telefonica.euro_iaas.paasmanager.model.SubNetworkInstance;
import com.telefonica.euro_iaas.paasmanager.util.SystemPropertiesProvider;

/**
 * @author henar
 */
public class NetworkInstanceManagerImpl implements NetworkInstanceManager {

    private NetworkInstanceDao networkInstanceDao = null;
    private NetworkClient networkClient = null;
    private SubNetworkInstanceManager subNetworkInstanceManager = null;
    private RouterManager routerManager = null;
    private SystemPropertiesProvider systemPropertiesProvider;

    private static Logger log = Logger.getLogger(NetworkInstanceManagerImpl.class);

    /**
     * To create a network.
     * 
     * @throws AlreadyExistsEntityException
     * @params claudiaData
     * @params network
     * @return NetworkInstance.class
     * @throws InvalidEntityException
     * @throws InfrastructureException
     * @throws AlreadyExistsEntityException
     * @throws EntityNotFoundException
     * @throws InfrastructureException
     */
    public NetworkInstance create(ClaudiaData claudiaData, NetworkInstance networkInstance, String region)
            throws InvalidEntityException, AlreadyExistsEntityException, EntityNotFoundException,
            InfrastructureException {
        log.debug("Create network instance " + networkInstance.getNetworkName());

        if (exists(networkInstance.getNetworkName())) {
            networkInstance = networkInstanceDao.load(networkInstance.getNetworkName());
            log.debug("The network already exists");
        } else {
            networkClient.deployNetwork(claudiaData, networkInstance, region);
            log.debug("Network isntance " + networkInstance.getNetworkName() + " : " + networkInstance.getIdNetwork()
                    + " deployed");
            try {
                createSubNetworksInstance(claudiaData, networkInstance, region);
                networkClient.addNetworkToPublicRouter(claudiaData, networkInstance, region);
                networkInstance = networkInstanceDao.create(networkInstance);
            } catch (InfrastructureException e) {
                log.warn("There is an error to deploy an subNet " + e.getMessage());
                restoreNetwork(claudiaData, networkInstance, region);
                throw new InfrastructureException("There is an error to deploy a subNet " + e.getMessage());
            }

        }
        return networkInstance;
    }

    /**
     * It restore the situation if there is a failure.
     * 
     * @param claudiaData
     * @param networkInstance
     * @throws EntityNotFoundException
     * @throws InvalidEntityException
     * @throws InfrastructureException
     */
    private void restoreNetwork(ClaudiaData claudiaData, NetworkInstance networkInstance, String region)
            throws EntityNotFoundException, InvalidEntityException, InfrastructureException {
        for (SubNetworkInstance subNet : networkInstance.getSubNets()) {
            if (subNetworkInstanceManager.isSubNetworkDeployed(claudiaData, subNet, region)) {
                subNetworkInstanceManager.delete(claudiaData, subNet, region);
            }
        }
        log.debug("Deleting the network");
        networkClient.destroyNetwork(claudiaData, networkInstance, region);

        networkInstance.setSubNets(null);
        networkInstanceDao.update(networkInstance);
        networkInstanceDao.remove(networkInstance);

    }

    /**
     * It creates a subnet in the network.
     */
    private void createSubNetworksInstance(ClaudiaData claudiaData, NetworkInstance networkInstance, String region)
            throws InvalidEntityException, AlreadyExistsEntityException, InfrastructureException

    {
        Set<SubNetworkInstance> subNetAxu = networkInstance.cloneSubNets();

        for (SubNetworkInstance subNet : subNetAxu) {

            log.debug("SubNetwork " + subNet.getName() + " id net " + subNet.getIdNetwork());
            subNet.setIdNetwork(networkInstance.getIdNetwork());
            networkInstance.updateSubNet(subNet);
            subNet = subNetworkInstanceManager.create(claudiaData, subNet, region);
            
            log.debug("SubNetwork " + subNet.getName() + " id net " + subNet.getIdNetwork() + " in network  "
                    + networkInstance.getNetworkName() + " deployed");
        }
    }

    /**
     * To remove a network.
     * 
     * @params claudiaData
     * @params network
     */
    public void delete(ClaudiaData claudiaData, NetworkInstance networkInstance, String region)
            throws EntityNotFoundException, InvalidEntityException, InfrastructureException {
        log.debug("Destroying network " + networkInstance.getNetworkName());

        log.debug("Deleting the public interface interfaces");
        networkInstance = networkInstanceDao.load(networkInstance.getNetworkName());
        networkClient.deleteNetworkToPublicRouter(claudiaData, networkInstance, region);
        log.debug("Deleting the subnets");
        Set<SubNetworkInstance> subNetAux = networkInstance.cloneSubNets();
        networkInstance.getSubNets().clear();
        networkInstanceDao.update(networkInstance);
        for (SubNetworkInstance subNet : subNetAux) {
            subNetworkInstanceManager.delete(claudiaData, subNet, region);
        }
        log.debug("Deleting the network");
        networkClient.destroyNetwork(claudiaData, networkInstance, region);
        try {
            networkInstanceDao.remove(networkInstance);
        } catch (Exception e) {
            log.error("Error to remove the network in BD " + e.getMessage());
            throw new InvalidEntityException(networkInstance);
        }

    }

    /**
     * To obtain the list of networks.
     * 
     * @return the network list
     */
    public List<NetworkInstance> findAll() {
        return networkInstanceDao.findAll();
    }

    /**
     * To obtain the list of networks.
     * 
     * @return the network list
     */
    public boolean exists(String networkInstance) {
        try {
            networkInstanceDao.load(networkInstance);
            return true;
        } catch (Exception e) {
            return false;
        }

    }
    
    public List<NetworkInstance> listNetworks (ClaudiaData claudiaData, String region) throws InfrastructureException {
        List<NetworkInstance> networkInstances = networkClient.loadAllNetwork(claudiaData, region);
        return networkInstances;
    }

    /**
     * To obtain the network.
     * 
     * @param networkName
     * @return the network
     */
    public NetworkInstance load(String networkName) throws EntityNotFoundException {
        return networkInstanceDao.load(networkName);
    }

    public void setNetworkClient(NetworkClient networkClient) {
        this.networkClient = networkClient;
    }

    public void setNetworkInstanceDao(NetworkInstanceDao networkInstanceDao) {
        this.networkInstanceDao = networkInstanceDao;
    }

    public void setRouterManager(RouterManager routerManager) {
        this.routerManager = routerManager;
    }

    public void setSubNetworkInstanceManager(SubNetworkInstanceManager subNetworkInstanceManager) {
        this.subNetworkInstanceManager = subNetworkInstanceManager;
    }

    /**
     * @param systemPropertiesProvider
     *            the systemPropertiesProvider to set
     */
    public void setSystemPropertiesProvider(SystemPropertiesProvider systemPropertiesProvider) {
        this.systemPropertiesProvider = systemPropertiesProvider;
    }

    public NetworkInstance update(NetworkInstance networkInstance) throws InvalidEntityException {
        return networkInstanceDao.update(networkInstance);
    }

    public int getNumberDeployedNetwork(ClaudiaData claudiaData, String region) throws InfrastructureException {
        return networkClient.loadAllNetwork(claudiaData, region).size();
    }

}